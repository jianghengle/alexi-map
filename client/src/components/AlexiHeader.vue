<template>
  <div>
    <nav class="navbar is-transparent">
      <div class="navbar-brand">
        <router-link class="navbar-item is-primary app-name" :to="'/'">
          Global Daily Evapo-Transpiration (GloDET)
        </router-link>
      </div>

      <div class="navbar-menu is-active">
        <div class="navbar-start">
        </div>

        <div class="navbar-end">
          <router-link v-if="routePath != '/'" class="navbar-item" :to="'/'">
            <span class="nav-icon"><icon name="home"></icon></span>Home
          </router-link>
          <div v-if="username" class="navbar-item has-dropdown is-hoverable">
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
      var email = this.$store.state.user.email
      if(email){
        var index = email.indexOf('@')
        return email.slice(0, index)
      }
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
