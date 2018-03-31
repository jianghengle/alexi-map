<template>
  <div class="header-block">
    <nav class="navbar is-transparent header-bar">
      <div class="navbar-brand">
        <a class="navbar-item is-primary university-name" href="https://www.unl.edu/">
          UNIVERSITY OF NEBRASKA-LINCOLN
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
  background-color: #05485A;
  color: white;
  min-height: 40px;
  height: 40px;

  .university-name {
    color: white;
    height: 40px;
    font-family: "Arial Black", Gadget, sans-serif;
    font-size: 12px;
    margin-left: 80px;
  }

  .bar-item {
    color: white;
    font-size: 14px;
  }
}

.nav-icon {
  position: relative;
  top: 4px;
  right: 5px;
}

.menu-bar {
  height: 80px;

  .app-name {
    font-size: 28px;
    margin: auto;
    color: black;
    font-family: Impact, Charcoal, sans-serif;
    margin-left: 30px;

    .app-logo {
      max-height: 60px;
      height: 60px;
      width: 55px;
    }
  }

  .menu-item {
    color: #05485A;
    font-size: 16px;
    font-weight: bold;
    font-family: Futura,Trebuchet MS,Arial,sans-serif;
  }
}

.color-seperator{
  height: 3px;
  background: linear-gradient(to right, #9f9a67, #3fb5bd);
}
</style>
