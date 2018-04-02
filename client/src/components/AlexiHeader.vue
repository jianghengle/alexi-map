<template>
  <div class="header-block">
    <nav class="navbar is-transparent header-bar">
      <div class="navbar-brand">
        <a class="navbar-item is-primary university-name" href="https://www.unl.edu/">
          UNIVERSITY OF NEBRASKA
        </a>
      </div>
      <div class="navbar-menu is-active">
        <div class="navbar-end">
          <div v-if="token" class="navbar-item has-dropdown is-hoverable">
            <router-link class="navbar-link bar-item" :to="'/profile'">
              <span class="nav-icon"><icon name="user"></icon></span>{{username}}
            </router-link>
            <div class="navbar-dropdown is-boxed">
              <router-link class="navbar-item" :to="'/profile'">
                Profile
              </router-link>
              <router-link class="navbar-item" :to="'/settings'">
                Settings
              </router-link>
            </div>
          </div>
          <router-link v-if="!token" class="navbar-item bar-item" :to="'/login'">
            <span class="nav-icon"><icon name="sign-in"></icon></span>Login
          </router-link>
          <a v-if="token" class="navbar-item bar-item" @click="logout">
            <span class="nav-icon"><icon name="sign-out"></icon></span>Logout
          </a>
        </div>
      </div>
    </nav>

    <nav class="navbar is-transparent menu-bar">
      <div class="navbar-brand">
        <router-link class="navbar-item is-primary app-name" :to="'/'">
          <img src="static/logo.png" class="app-logo">&nbsp;
          GloDET: Global Daily Evapo-Transpiration
        </router-link>
      </div>

      <div class="navbar-menu is-active">
        <div class="navbar-end">
          <router-link class="navbar-item menu-item" :to="'/about'">
            About
          </router-link>
          <router-link class="navbar-item menu-item" :to="'/documentation'">
            Documentation
          </router-link>
          <router-link class="navbar-item menu-item" :to="'/partners_n_projects'">
            Partners & Projects
          </router-link>
          <router-link class="navbar-item menu-item" :to="'/help'">
            Help
          </router-link>
        </div>
      </div>
    </nav>
    <div class="color-seperator"></div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-header',
  data () {
    return {
      showNav: false

    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    username () {
      return this.$store.state.user.name
    },
    routePath () {
      return this.$route.path
    },
  },
  methods: {
    logout () {
      delete Vue.http.headers.common['Authorization']
      this.$store.commit('user/reset')
      this.$router.push('/login')
      this.$nextTick(function(){
        this.$store.commit('tiles/setSetting', null)
      })
    },
  }
}
</script>

<style lang="scss" scoped>


.header-bar {
  background-color: #0e485a;
  color: white;
  min-height: 41px;
  height: 41px;

  .university-name {
    color: white;
    height: 40px;
    font-size: 12pt;
    font-weight: 600;
    letter-spacing: .05em;
    margin-left: 40px;
  }

  .bar-item {
    color: white;
    font-size: 12pt;
    font-weight: 600;
  }
}

.nav-icon {
  position: relative;
  top: 3px;
  right: 5px;
}

.menu-bar {
  height: 117px;

  .app-name {
    font-size: 32px;
    margin: auto;
    color: #0e485a;
    font-family: Impact, Charcoal, sans-serif;

    .app-logo {
      max-height: 70px;
      height: 70px;
      width: 65px;
    }
  }

  .menu-item {
    color: #0e485a;
    font-family: futura-pt-condensed,Futura PT Cond,futura-lt-condensed,sans-serif;
    font-size: 18px;
    font-weight: bold;
  }
}

.color-seperator{
  height: 5px;
  background: linear-gradient(90deg,#b19844 0,#97a05c 33%,#6fac7f 64%,#17c7d0)
}
</style>
