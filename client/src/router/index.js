import Vue from 'vue'
import Router from 'vue-router'
import AlexiMain from '@/components/AlexiMain'
import AlexiLogin from '@/components/AlexiLogin'
import AlexiSettings from '@/components/AlexiSettings'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'AlexiMain',
      component: AlexiMain
    },
    {
      path: '/login',
      name: 'AlexiLogin',
      component: AlexiLogin
    },
    {
      path: '/settings',
      name: 'AlexiSettings',
      component: AlexiSettings
    }
  ]
})
