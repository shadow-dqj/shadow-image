import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'

import HealthCard from '@/components/HealthCard.vue'

const globalStubs = {
  'el-card': {
    template: '<section><slot name="header" /><slot /></section>',
  },
  'el-tag': {
    template: '<span><slot /></span>',
  },
}

describe('HealthCard', () => {
  it('renders ready status by default', () => {
    const wrapper = mount(HealthCard, {
      global: {
        stubs: globalStubs,
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
        stubs: globalStubs,
      },
    })

    expect(wrapper.text()).toContain('pending')
    expect(wrapper.text()).toContain('等待初始化')
  })
})
