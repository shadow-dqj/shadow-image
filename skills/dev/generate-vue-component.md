# generate-vue-component

## 描述

生成 Vue 3 + TypeScript + Element Plus 组件。

## 触发条件

- 用户要求生成 Vue 组件
- "生成组件 / create component"
- "创建页面 / create page"

## 上下文依赖

- `docs/architecture/tech-stack.md` — 前端技术栈
- `docs/development/coding-standards.md` — Vue 编码规范

## 输入

- 组件名称
- 组件类型：页面 / 业务组件 / 通用组件
- 功能描述

## 输出

- `desktop/frontend/src/<type>/<ComponentName>.vue`

## 组件模板

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import type { ComponentProps, ComponentEmits } from './types'

interface Props {
  // define props
}

const props = withDefaults(defineProps<Props>(), {
  // defaults
})

const emit = defineEmits<{
  (e: 'update', value: unknown): void
  (e: 'close'): void
}>()

// state
const loading = ref(false)

// methods
async function handleSubmit() {
  loading.value = true
  try {
    // logic
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="component-name">
    <slot />
  </div>
</template>

<style scoped>
.component-name {
  /* styles */
}
</style>
```

## 依赖组件库

- **Element Plus** — 表单/表格/对话框等
- **Fabric.js** — Canvas 编辑相关组件
- **Pinia** — 状态管理

## 命名规范

| 类型 | 目录 | 命名 |
|------|------|------|
| 页面 | `views/` | `TaskListView.vue` |
| 业务组件 | `components/business/` | `ImageUploader.vue` |
| 通用组件 | `components/common/` | `StatusBadge.vue` |
