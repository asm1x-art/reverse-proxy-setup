import { EDomain, EIpStatus } from './lists.types';
export declare class GetIpRulesQueryDto {
    ip?: string;
    status?: EIpStatus;
    domain?: EDomain;
    page?: number;
    limit?: number;
}
export declare class UpdateIpStatusDto {
    id: string;
    status: EIpStatus;
}
export declare class UpdateIpRpsDto {
    id: string;
    rps: number;
}
export declare class CreateIpRuleDto {
    ip: string;
    status: EIpStatus;
    domain: EDomain;
    rps?: number;
}
