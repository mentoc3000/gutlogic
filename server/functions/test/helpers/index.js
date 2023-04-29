"use strict";
// Ava excludes files in **/helpers/** from the test runner.
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.fft = void 0;
var firebase_functions_test_1 = __importDefault(require("firebase-functions-test"));
exports.fft = (0, firebase_functions_test_1.default)({
    projectId: "gutlogic-dev"
}, process.env.GOOGLE_APPLICATION_CREDENTIALS);
