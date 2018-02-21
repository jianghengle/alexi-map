import Vue from 'vue'
import Router from 'vue-router'
import AlexiMain from '@/components/AlexiMain'
import AlexiLogin from '@/components/AlexiLogin'
import AlexiRegister from '@/components/AlexiRegister'
import AlexiSettings from '@/components/AlexiSettings'
import AlexiProfile from '@/components/AlexiProfile'

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
      path: '/register',
      name: 'AlexiRegister',
      component: AlexiRegister
    },
    {
      path: '/settings',
      name: 'AlexiSettings',
      component: AlexiSettings
    },
    {
      path: '/profile',
      name: 'AlexiProfile',
      component: AlexiProfile
    }
  ]
})
