import { Strategy } from 'passport-local';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException, Inject, forwardRef } from '@nestjs/common';
import { AuthService } from './auth.service.js';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
    constructor(@Inject(forwardRef(() => AuthService)) private authService: AuthService) {
        super({ usernameField: 'email' });
    }

    async validate(email: string, password: string): Promise<any> {
        const user = await this.authService.validateUser(email, password);
        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }
        return user;
    }
}
