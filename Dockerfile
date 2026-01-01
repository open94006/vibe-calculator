# === 階段一：編譯前端 React ===
FROM node:20-slim AS client-builder
WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
# 確保 client/package.json 裡有 "build" 腳本 (通常產生 dist 或 build 資料夾)
RUN npm run build

# === 階段二：編譯後端 TypeScript ===
FROM node:20-slim AS server-builder
WORKDIR /app/server
COPY server/package*.json ./
RUN npm install
COPY server/ ./
# 重要：確保 server/package.json 裡有 "build": "tsc"
RUN npm run build

# === 階段三：最終執行環境 (生產環境) ===
FROM node:20-slim
WORKDIR /app

# 只安裝後端生產環境需要的套件
# 這裡我們複製 server 的 package.json 到根目錄來執行
COPY server/package*.json ./
RUN npm install --production

# 複製編譯結果
# 1. 將後端編譯出的 JS (原本在 server/dist) 複製到 /app/dist
COPY --from=server-builder /app/server/dist ./dist
# 2. 將前端編譯出的靜態檔 (原本在 client/dist) 複製到 /app/public
# 請確保您的後端 index.ts 有設定 app.use(express.static('public'))
COPY --from=client-builder /app/client/dist ./public

# 設定環境變數
ENV NODE_ENV=production
ENV PORT=8080

# 啟動命令
# 這裡的路徑是相對於 WORKDIR /app，所以是 dist/index.js
CMD ["node", "dist/index.js"]