"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var config = {
    AWS_ACCESS_KEY_ID: '',
    AWS_SECRET_ACCESS_KEY: '',
    HOST: 'URL.YOURREGION.amazonaws.com',
    REGION: 'YOURREGION',
    PATH: '/graphql',
    ENDPOINT: '',
};
config.ENDPOINT = "https://" + config.HOST + config.PATH;
exports.default = config;