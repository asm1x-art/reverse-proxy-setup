export enum EIpStatus {
  BLACKLIST = 'blacklist',
  WHITELIST = 'whitelist',
}

export enum EDomain {
  DEV = 'dev',
  TEST = 'test',
  PRODUCTION = 'production',
}

export interface IIpRule {
  id: string; // UUID
  ip: string;
  status: EIpStatus;
  domain: EDomain;
  rps: number; // 0 = безлимит
  createdAt: string; // ISO
  updatedAt: string; // ISO
}
