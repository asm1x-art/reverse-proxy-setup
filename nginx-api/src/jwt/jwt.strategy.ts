// src/auth/jwt.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import {
  ExtractJwt,
  Strategy,
  StrategyOptionsWithoutRequest,
} from 'passport-jwt';

// опишите свой интерфейс payload-а
interface JwtPayload {
  sub: number;
  email?: string;
  iat?: number;
  exp?: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor() {
    const opts: StrategyOptionsWithoutRequest = {
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey:
        process.env.JWT_SECRET ??
        'elYXWgbORSog7GSlwe+xI+CodoJl8IqY5FO7m0KsI2o=',
      algorithms: ['HS256'],
      passReqToCallback: false,
    };
    super(opts);
  }

  validate(payload: JwtPayload) {
    return payload;
  }
}
