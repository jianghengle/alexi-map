import Vue from 'vue'
import Router from 'vue-router'
import AlexiMain from '@/components/AlexiMain'
import AlexiLogin from '@/components/AlexiLogin'
import AlexiRegister from '@/components/AlexiRegister'
import AlexiSettings from '@/components/AlexiSettings'
import AlexiProfile from '@/components/AlexiProfile'
import AlexiAbout from '@/components/AlexiAbout'
import AlexiDocumentation from '@/components/AlexiDocumentation'
import AlexiPartnersNProjects from '@/components/AlexiPartnersNProjects'
import AlexiHelp from '@/components/AlexiHelp'
import AlexiAdmin from '@/components/AlexiAdmin'
import AdminUser from '@/components/AdminUser'

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
    },
    {
      path: '/about',
      name: 'AlexiAbout',
      component: AlexiAbout
    },
    {
      path: '/documentation',
      name: 'AlexiDocumentation',
      component: AlexiDocumentation
    },
    {
      path: '/partners_n_projects',
      name: 'AlexiPartnersNProjects',
      component: AlexiPartnersNProjects
    },
    {
      path: '/help',
      name: 'AlexiHelp',
      component: AlexiHelp
    },
    {
      path: '/admin',
      name: 'AlexiAdmin',
      component: AlexiAdmin
    },
    {
      path: '/admin_user/:userId',
      name: 'AdminUser',
      component: AdminUser
    }
  ]
})
