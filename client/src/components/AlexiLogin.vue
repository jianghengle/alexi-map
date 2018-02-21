<template>
  <div class="login-page">
    <div class="container">
      <div class="welcome">
        Thank you for accessing the GloDET data viewer!<br/>
        Please login or <router-link :to="'/register'">register a new account</router-link>.
      </div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="text" placeholder="Email" v-model="email" @keyup.enter="login" v-focus>
          <span class="icon is-small is-left">
            <icon name="envelope"></icon>
          </span>
        </p>
      </div>

      <div class="field">
        <p class="control has-icons-left">
          <input class="input login-text" type="password" placeholder="Password" v-model="password" @keyup.enter="login">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </p>
      </div>

      <div class="field">
        <p class="control">
          <label class="checkbox">
            <input type="checkbox" v-model="rememberMe">
            Remember me
          </label>
        </p>
      </div>

      <div v-if="error" class="notification is-danger login-text">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>

      <div class="field">
        <p class="control">
          <button class="button" :class="{'is-loading': waiting}" @click="login">Login</button>
        </p>
      </div>

      <div>
        <a>Forgot your password?</a>
      </div>
      <div>
        <router-link :to="'/register'">Register a new account</router-link>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'alexi-login',
  data () {
    return {
      email: '',
      password: '',
      rememberMe: '',
      error: '',
      waiting: false
    }
  },
  methods: {
    login () {
      this.email = this.email.trim().toLowerCase()
      this.waiting = true
      var message = {email: this.email, password: this.password}
      this.$http.post(xHTTPx + '/get_auth_token', message).then(response => {
        var token = response.body.token
        var name = response.body.name
        Vue.http.headers.common['Authorization'] = token
        this.$store.commit('user/setToken', token)
        this.$store.commit('user/setName', name)
        this.$store.commit('user/setEmail', this.email)
        if (this.rememberMe) {
          localStorage.setItem('token', token)
          localStorage.setItem('email', this.email)
        }
        this.waiting = false
        this.$store.commit('tiles/setSetting', null)
        this.$router.push('/')
      }, response => {
        this.error = 'Failed to authorize user!'
        this.$store.commit('user/reset')
        this.waiting = false
      })
    }
  }
}
</script>

<style lang="scss" scoped>

.login-page {
  padding: 20px;
  margin-top: 50px;
}

.welcome {
  padding-bottom: 15px;
  font-weight: bold;
}

.login-text {
  max-width: 500px;
}
</style>
