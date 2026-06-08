import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'

import HealthCard from '@/components/HealthCard.vue'

describe('HealthCard', () => {
  it('renders ready status by default', () => {
    const wrapper = mount(HealthCard, {
      global: {
        stubs: ['el-card', 'el-tag'],
      },
    })

    expect(wrapper.text()).toContain('ready')
    expect(wrapper.text()).toContain('前端验证已启用')
  })

  it('renders pending status', () => {
    const wrapper = mount(HealthCard, {
      props: {
        status: 'pending',
      },
      global: {
        stubs: ['el-card', 'el-tag'],
      },
    })

    expect(wrapper.text()).toContain('pending')
    expect(wrapper.text()).toContain('等待初始化')
  })
})
