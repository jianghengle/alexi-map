import Vue from 'vue'
import Router from 'vue-router'
import AlexiMain from '@/components/AlexiMain'
import AlexiLogin from '@/components/AlexiLogin'

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
    }
  ]
})
