export declare enum EIpStatus {
    BLACKLIST = "blacklist",
    WHITELIST = "whitelist"
}
export declare enum EDomain {
    DEV = "dev",
    TEST = "test",
    PRODUCTION = "production"
}
export interface IIpRule {
    id: string;
    ip: string;
    status: EIpStatus;
    domain: EDomain;
    rps: number;
    createdAt: string;
    updatedAt: string;
}
