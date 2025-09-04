import js from '@eslint/js';
import prettier from 'eslint-plugin-prettier';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['**/*.{js,ts}'],
    languageOptions: {
      parserOptions: {
        ecmaFeatures: {},
      },
    },
    plugins: {
      prettier,
    },
    rules: {
      // Prettier integration
      ...prettier.configs.recommended.rules,
      'prettier/prettier': 'error',

      // TypeScript rules overrides
      '@typescript-eslint/no-unused-vars': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-empty-function': 'warn',
      '@typescript-eslint/no-non-null-assertion': 'warn',

      // Disable floating promises rule for model package
      '@typescript-eslint/no-floating-promises': 'off',
    },
  },
  // Type-checked rules for TypeScript files only
  ...tseslint.configs.recommendedTypeChecked.map((config) => ({
    ...config,
    files: ['**/*.ts'],
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  })),
  {
    ignores: [
      'build/**',
      'node_modules/**',
      '*.config.js',
      '*.config.ts',
      'eslint.config.js',
      'eslint.config.mjs',
    ],
  },
);
