# --- 階段一：編譯前端 React ---
FROM node:20 AS client-builder
WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build 
# 註：build 後通常會產生 dist 或 build 資料夾

# --- 階段二：設定後端並整合 ---
FROM node:20-slim
WORKDIR /app

# 複製後端程式碼
COPY server/package*.json ./
RUN npm install --production
COPY server/ ./

# 將階段一編譯好的前端檔案，複製到後端指定的靜態資料夾
# 這裡假設後端程式碼中設定 app.use(express.static('public'))
COPY --from=client-builder /app/client/dist ./public

# Cloud Run 規範
ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

CMD ["node", "index.js"]