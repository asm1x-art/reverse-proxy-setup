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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ListsController = void 0;
const common_1 = require("@nestjs/common");
const lists_service_1 = require("./lists.service");
const lists_dto_1 = require("./lists.dto");
const swagger_1 = require("@nestjs/swagger");
let ListsController = class ListsController {
    listsService;
    constructor(listsService) {
        this.listsService = listsService;
    }
    async create(dto) {
        return this.listsService.createIpRule(dto);
    }
    async findAll(query) {
        return this.listsService.getIpRules(query);
    }
    async findOne(id) {
        return this.listsService.getById(id);
    }
    async remove(id) {
        return this.listsService.deleteIpRule(id);
    }
    async updateStatus(dto) {
        return this.listsService.updateIpStatus(dto.id, { status: dto.status });
    }
    async updateRps(dto) {
        return this.listsService.updateIpRps(dto.id, { rps: dto.rps });
    }
};
exports.ListsController = ListsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Добавить новый IP' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [lists_dto_1.CreateIpRuleDto]),
    __metadata("design:returntype", Promise)
], ListsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Получить список IP с фильтрацией' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [lists_dto_1.GetIpRulesQueryDto]),
    __metadata("design:returntype", Promise)
], ListsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Получить конкретный IP по ID' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: 'string' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ListsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Удалить IP по ID' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: 'string' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ListsController.prototype, "remove", null);
__decorate([
    (0, common_1.Patch)('status'),
    (0, swagger_1.ApiOperation)({ summary: 'Обновить статус IP' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [lists_dto_1.UpdateIpStatusDto]),
    __metadata("design:returntype", Promise)
], ListsController.prototype, "updateStatus", null);
__decorate([
    (0, common_1.Patch)('rps'),
    (0, swagger_1.ApiOperation)({ summary: 'Обновить лимит RPS' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [lists_dto_1.UpdateIpRpsDto]),
    __metadata("design:returntype", Promise)
], ListsController.prototype, "updateRps", null);
exports.ListsController = ListsController = __decorate([
    (0, swagger_1.ApiTags)('IP Rules'),
    (0, common_1.Controller)('lists'),
    __metadata("design:paramtypes", [lists_service_1.ListsService])
], ListsController);
//# sourceMappingURL=lists.controller.js.map