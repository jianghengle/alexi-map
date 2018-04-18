<template>
  <div>
    <div class="top-bar">
      <div class="top-bar-left">
        <a class="university-name" href="https://www.unl.edu/">
          UNIVERSITY OF NEBRASKA
        </a>
      </div>

      <div class="top-bar-right">

        <div v-if="token" class="dropdown is-hoverable top-bar-dropdown">
          <div class="dropdown-trigger">
            <router-link class="username" :to="'/profile'">
              <span class="nav-icon"><icon name="user"></icon></span>{{username}}
            </router-link>
          </div>
          <div class="dropdown-menu" role="menu">
            <div class="dropdown-content user-dropdown">
              <router-link class="dropdown-item" :to="'/profile'">
                Profile
              </router-link>
              <router-link class="dropdown-item" :to="'/settings'">
                Settings
              </router-link>
            </div>
          </div>
        </div>

        <router-link v-if="!token" class="top-bar-item" :to="'/login'">
          <span class="nav-icon"><icon name="sign-in"></icon></span>Login
        </router-link>
        <a v-if="token" class="top-bar-item" @click="logout">
          <span class="nav-icon"><icon name="sign-out"></icon></span>Logout
        </a>
      </div>
    </div>

    <nav class="navbar">
      <div class="navbar-brand">
        <router-link class="navbar-item app-name" :to="'/'">
          <img src="static/logo.png" class="app-logo">&nbsp;
          <span class="app-main-name">GloDET</span>
          <span class="app-sub-name">Global Daily Evapo-Transpiration</span>
        </router-link>
        <div class="navbar-burger burger" :class="{'is-active': menuActive}"
          @click="menuActive = !menuActive">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>

      <div class="navbar-menu" :class="{'is-active': menuActive}">
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
      menuActive: false
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

.top-bar {
  background-color: #0e485a;
  color: white;
  height: 41px;


  .top-bar-left {
    float: left;
    margin-left: 20px;

    .university-name {
      line-height: 41px;
      color: white;
      font-size: 12pt;
      font-weight: 600;
      letter-spacing: .05em;
    }

    .university-name:hover {
      color: #eeeeee;
    }
  }

  .top-bar-right {
    float: right;
    margin-right: 10px;

    .top-bar-dropdown {
      margin-right: 10px;
      line-height: 41px;

      .username {
        color: white;
        font-size: 12pt;
        font-weight: 600;
      }

      .username:hover {
        color: #eeeeee;
      }

      .user-dropdown {
        width: 120px;
        min-width: 120px;
        position: relative;
        top: -2px;
        left: -10px;
      }
    }

    .top-bar-item {
      margin-left: 10px;
      color: white;
      font-size: 12pt;
      font-weight: 600;
      line-height: 40px;
    }

    .top-bar-item:hover {
      color: #eeeeee;
    }
  }
}

.nav-icon {
  position: relative;
  top: 3px;
  right: 5px;
}

.app-name {
  width: 300px;

  .app-logo {
    max-height: 70px;
    height: 70px;
    width: 65px;
  }

  .app-main-name {
    font-size: 32px;
    color: #0e485a;
    font-family: "Arial Black", Gadget, sans-serif;
    position: relative;
    top: -10px;
  }

  .app-sub-name {
    font-size: 18px;
    color: #0e485a;
    font-family: futura-pt-condensed,Futura PT Cond,futura-lt-condensed,sans-serif;
    position: relative;
    top: 18px;
    left: -126px;
    white-space: nowrap;
  }
}

.menu-item {
  color: #0e485a;
  font-family: futura-pt-condensed,Futura PT Cond,futura-lt-condensed,sans-serif;
  font-size: 18px;
  font-weight: bold;
}

.color-seperator{
  height: 5px;
  background: linear-gradient(90deg,#b19844 0,#97a05c 33%,#6fac7f 64%,#17c7d0)
}
</style>
