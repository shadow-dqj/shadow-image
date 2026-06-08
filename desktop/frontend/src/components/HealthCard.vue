<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  status?: 'ready' | 'pending'
}>(), {
  status: 'ready',
})

const statusText = computed(() => (props.status === 'ready' ? '前端验证已启用' : '等待初始化'))
</script>

<template>
  <el-card
    class="health-card"
    shadow="hover"
  >
    <template #header>
      <div class="card-header">
        <span>开发状态</span>
        <el-tag :type="status === 'ready' ? 'success' : 'warning'">
          {{ status }}
        </el-tag>
      </div>
    </template>
    <p>{{ statusText }}</p>
  </el-card>
</template>

<style scoped>
.health-card {
  width: min(100%, 520px);
  margin-top: 24px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
