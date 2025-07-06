"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const swagger_1 = require("@nestjs/swagger");
const ORIGINS = [
    'http://localhost:3000/',
    'https://dev.cringepay.xyz',
    'https://test.cringepay.xyz',
    'https://cringepay.xyz',
];
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const config = new swagger_1.DocumentBuilder()
        .setTitle('Cringepay Admin TECH API')
        .setDescription('Логи, фильтры, блокировки, лимиты и т.д.')
        .setVersion('1.0')
        .build();
    app.setGlobalPrefix('api/tech');
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup('docs', app, document, {
        useGlobalPrefix: true,
        swaggerOptions: {
            url: '/api/tech/docs-json',
        },
    });
    app.enableCors({
        origin: ORIGINS,
        credentials: false,
    });
    await app.listen(15000, '0.0.0.0');
}
bootstrap().catch((e) => console.log(e));
//# sourceMappingURL=main.js.map