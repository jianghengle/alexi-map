<template>
  <div>
    <nav class="navbar is-transparent">
      <div class="navbar-brand">
        <router-link class="navbar-item is-primary app-name" :to="'/'">
          <img src="static/logo.png" width="30">&nbsp;
          Global Daily Evapo-Transpiration (GloDET)
        </router-link>
      </div>

      <div class="navbar-menu is-active">
        <div class="navbar-start">
          <router-link class="navbar-item" :to="'/'">
            Home
          </router-link>
          <router-link class="navbar-item" :to="'/about'">
            About
          </router-link>
          <router-link class="navbar-item" :to="'/documentation'">
            Documentation
          </router-link>
          <router-link class="navbar-item" :to="'/partners_n_projects'">
            Partners & Projects
          </router-link>
          <router-link class="navbar-item" :to="'/help'">
            Help
          </router-link>
        </div>

        <div class="navbar-end">
          <div v-if="token" class="navbar-item has-dropdown is-hoverable">
            <router-link class="navbar-link" :to="'/profile'">
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
          <router-link v-if="!token" class="navbar-item" :to="'/login'">
            <span class="nav-icon"><icon name="sign-in"></icon></span>Login
          </router-link>
          <a v-if="token" class="navbar-item" @click="logout">
            <span class="nav-icon"><icon name="sign-out"></icon></span>Logout
          </a>
        </div>
      </div>
    </nav>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-header',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
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

.app-name {
  font-weight: bold;
  font-size: 20px;
  margin: auto;
}


.nav-icon {
  position: relative;
  top: 4px;
  right: 5px;
}
</style>
