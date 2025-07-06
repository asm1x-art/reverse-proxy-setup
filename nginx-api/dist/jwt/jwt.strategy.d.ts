import { Strategy, StrategyOptionsWithoutRequest } from 'passport-jwt';
interface JwtPayload {
    sub: number;
    email?: string;
    iat?: number;
    exp?: number;
}
declare const JwtStrategy_base: new (...args: [opt: import("passport-jwt").StrategyOptionsWithRequest] | [opt: StrategyOptionsWithoutRequest]) => Strategy & {
    validate(...args: any[]): unknown;
};
export declare class JwtStrategy extends JwtStrategy_base {
    constructor();
    validate(payload: JwtPayload): JwtPayload;
}
export {};
