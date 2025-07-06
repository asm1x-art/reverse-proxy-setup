"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreateIpRuleDto = exports.UpdateIpRpsDto = exports.UpdateIpStatusDto = exports.GetIpRulesQueryDto = void 0;
const class_validator_1 = require("class-validator");
const lists_types_1 = require("./lists.types");
const swagger_1 = require("@nestjs/swagger");
const logs_types_1 = require("../logs/logs.types");
class GetIpRulesQueryDto {
    ip;
    status;
    domain;
    page = 1;
    limit = 50;
}
exports.GetIpRulesQueryDto = GetIpRulesQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'IP-адрес (частичное или полное совпадение)',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsIP)(),
    __metadata("design:type", String)
], GetIpRulesQueryDto.prototype, "ip", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        enum: lists_types_1.EIpStatus,
        description: 'Статус IP (whitelist, blacklist)',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(lists_types_1.EIpStatus),
    __metadata("design:type", String)
], GetIpRulesQueryDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        enum: lists_types_1.EDomain,
        description: 'Домен (dev, test, production)',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(lists_types_1.EDomain),
    __metadata("design:type", String)
], GetIpRulesQueryDto.prototype, "domain", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ default: 1, minimum: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], GetIpRulesQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ default: 50, minimum: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], GetIpRulesQueryDto.prototype, "limit", void 0);
class UpdateIpStatusDto {
    id;
    status;
}
exports.UpdateIpStatusDto = UpdateIpStatusDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'ID записи' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateIpStatusDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: lists_types_1.EIpStatus, description: 'Новый статус IP' }),
    (0, class_validator_1.IsEnum)(lists_types_1.EIpStatus),
    __metadata("design:type", String)
], UpdateIpStatusDto.prototype, "status", void 0);
class UpdateIpRpsDto {
    id;
    rps;
}
exports.UpdateIpRpsDto = UpdateIpRpsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'ID записи' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateIpRpsDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Новый лимит RPS (0 — без ограничений)' }),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], UpdateIpRpsDto.prototype, "rps", void 0);
class CreateIpRuleDto {
    ip;
    status;
    domain;
    rps = 0;
}
exports.CreateIpRuleDto = CreateIpRuleDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'IP-адрес' }),
    (0, class_validator_1.IsIP)(),
    __metadata("design:type", String)
], CreateIpRuleDto.prototype, "ip", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        enum: lists_types_1.EIpStatus,
        description: 'Статус IP (whitelist или blacklist)',
    }),
    (0, class_validator_1.IsEnum)(lists_types_1.EIpStatus),
    __metadata("design:type", String)
], CreateIpRuleDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        enum: logs_types_1.HostType,
        description: 'Домен, к которому относится правило',
    }),
    (0, class_validator_1.IsEnum)(lists_types_1.EDomain),
    __metadata("design:type", String)
], CreateIpRuleDto.prototype, "domain", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'RPS лимит. 0 — без ограничений',
        default: 0,
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateIpRuleDto.prototype, "rps", void 0);
//# sourceMappingURL=lists.dto.js.map