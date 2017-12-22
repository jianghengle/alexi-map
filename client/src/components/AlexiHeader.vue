<template>
  <div>
    <nav class="navbar is-transparent header">
      <div class="navbar-brand">
        <router-link class="nav-item app-name" :to="'/'">
          Alexi Explorer
        </router-link>
      </div>

      <div class="navbar-menu is-active menu">
        <div class="navbar-start">
        </div>

        <div class="navbar-end">
          <div v-if="username" class="navbar-item">
            <router-link class="app-item" :to="'/login'">
              <span class="nav-icon"><icon name="user"></icon></span>{{username}}
            </router-link>
          </div>
          <div v-if="!token" class="navbar-item">
            <router-link class="app-item" :to="'/login'">
              <span class="nav-icon"><icon name="sign-in"></icon></span>Login
            </router-link>
          </div>
          <div v-if="token" class="navbar-item">
            <a class="app-item" @click="logout">
              <span class="nav-icon"><icon name="sign-out"></icon></span>Logout
            </a>
          </div>
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
    }
  },
  methods: {
    logout () {
      delete Vue.http.headers.common['Authorization']
      this.$store.commit('user/reset')
      this.$router.push('/login')
    },
  }
}
</script>

<style lang="scss" scoped>
.header {
  background-color: black;

  .menu {
    background-color: black;
  }
}

.app-name {
  color: #FFFFFF;
  font-weight: bold;
  font-size: 18px;
  margin: auto;
  padding-left: 20px;
}

.app-name:hover {
  color: #EEEEEE!important;
}

.app-item {
  color: #FFFFFF!important;
  cursor: pointer;
}

.app-item:hover {
  color: #EEEEEE!important;
}

.nav-icon {
  position: relative;
  top: 4px;
  right: 5px;
}
</style>
