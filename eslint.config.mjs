import js from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';
import json from '@eslint/json';
import pluginYml from 'eslint-plugin-yml';
import globals from 'globals';
import { defineConfig } from 'eslint/config';

export default defineConfig([
  {
    files: ['**/*.{js,mjs,cjs}'],
    plugins: { js },
    extends: [
      js.configs.recommended,
      stylistic.configs.recommended,
    ],
    rules: {
      '@stylistic/arrow-parens': 'error',
      '@stylistic/arrow-spacing': 'error',
      '@stylistic/brace-style': ['error', '1tbs', { allowSingleLine: true }],
      '@stylistic/comma-dangle': ['error', 'always-multiline'],
      '@stylistic/indent': ['error', 2],
      '@stylistic/quotes': ['error', 'single'],
      '@stylistic/semi': ['error', 'always'],
      '@stylistic/semi-spacing': ['error'],
      '@stylistic/space-before-function-paren': ['error', {
        anonymous: 'never',
        named: 'never',
        asyncArrow: 'always',
      }],
    },
    languageOptions: { globals: globals.node },
  },
  { files: ['**/*.js'], languageOptions: { sourceType: 'commonjs' } },
  {
    files: ['**/*.json'],
    ignores: ['**/package-lock.json'],
    plugins: { json },
    language: 'json/json',
    extends: ['json/recommended'],
  },
  {
    files: ['**/*.yml'],
    plugins: { yml: pluginYml },
    language: 'yml/yaml',
    extends: ['yml/recommended'],
    rules: {
      'yml/indent': ['error', 2],
      'yml/no-empty-mapping-value': 'off',
      // 'yml/key-spacing': ['error', { beforeColon: false, afterColon: true }],
      // 'yml/no-multiple-empty-lines': ['error', { max: 1 }],
      // 'yml/spaced-comment': ['error', 'always'],
    },
  },
]);
