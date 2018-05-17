<template>
  <div class="settings-page">
    <div class="container users-container">
      <div class="spinner-container" v-if="waiting">
        <icon name="spinner" class="icon is-medium fa-spin"></icon>
      </div>
      <div v-if="error" class="notification is-danger">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      
      <div>
        <table class="table is-hoverable is-fullwidth">
          <thead>
            <tr>
              <th>Total {{users.length}}</th>
              <th>
                <span class="clickable" @click="sortUsers('email')">Email</span>
                <span v-if="sortOption.field=='email'">
                  <icon class="asc-icon" name="sort-asc" v-if="!sortOption.reverse"></icon>
                  <icon name="sort-desc" v-if="sortOption.reverse"></icon>
                </span>
              </th>
              <th>
                <span class="clickable" @click="sortUsers('firstName')">First Name</span>
                <span v-if="sortOption.field=='firstName'">
                  <icon class="asc-icon" name="sort-asc" v-if="!sortOption.reverse"></icon>
                  <icon name="sort-desc" v-if="sortOption.reverse"></icon>
                </span>
              </th>
              <th>
                <span class="clickable" @click="sortUsers('lastName')">Last Name</span>
                <span v-if="sortOption.field=='lastName'">
                  <icon class="asc-icon" name="sort-asc" v-if="!sortOption.reverse"></icon>
                  <icon name="sort-desc" v-if="sortOption.reverse"></icon>
                </span>
              </th>
              <th>
                <span class="clickable" @click="sortUsers('registered')">Registered At</span>
                <span v-if="sortOption.field=='registered'">
                  <icon class="asc-icon" name="sort-asc" v-if="!sortOption.reverse"></icon>
                  <icon name="sort-desc" v-if="sortOption.reverse"></icon>
                </span>
              </th>
              <th>
                <span class="clickable" @click="sortUsers('status')">Status</span>
                <span v-if="sortOption.field=='status'">
                  <icon class="asc-icon" name="sort-asc" v-if="!sortOption.reverse"></icon>
                  <icon name="sort-desc" v-if="sortOption.reverse"></icon>
                </span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr class="clickable" v-for="u, i in users" :key="u.id" @click="viewUser(u)">
              <td>{{i+1}}</td>
              <td>{{u.email}}</td>
              <td>{{u.firstName}}</td>
              <td>{{u.lastName}}</td>
              <td>{{u.registered}}</td>
              <td :class="{'has-text-danger': u.status == 'Inactive',
                           'has-text-warning': u.status == 'Verifying',
                           'has-text-success': u.status == 'Active'}">
                {{u.status}}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import DateForm from 'dateformat'

export default {
  name: 'alexi-admin',
  data () {
    return {
      error: '',
      waiting: false,
      users: [],
      sortOption: {field: 'status', reverse: false}
    }
  },
  methods: {
    getUsers () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_all_users').then((response) => {
        var resp = response.body
        this.users = resp.map(function(u){
          var utcSeconds = u.registeredAt
          var d = new Date(0)
          d.setUTCSeconds(utcSeconds)
          u.registered = DateForm(d, 'mmm dd yyyy h:MM TT')
          return u
        })
        this.sortUsers()
        this.waiting = false
      }, (response) => {
        this.error = 'Failed to get all users: ' + JSON.stringify(response.body)
        this.waiting = false
      })
    },
    viewUser (u) {
      this.$router.push('/admin_user/' + u.id)
    },
    sortUsers (field) {
      if(field){
        if(field == this.sortOption.field){
          this.sortOption.reverse = !this.sortOption.reverse
        }else{
          this.sortOption.field = field
        }
      }
      this.$store.commit('user/setSortOption', this.sortOption)
      this.users.sort(this.compareUsers)
    },
    compareUsers (a, b) {
      var field = this.sortOption.field
      var v1 = a[field]
      var v2 = b[field]
      if(field == 'email' || field == 'firstName' || field == 'lastName'){
        return this.sortOption.reverse ? v2.localeCompare(v1) : v1.localeCompare(v2)
      }
      if(field == 'registered'){
        v1 = a.registeredAt
        v2 = b.registeredAt
        return this.sortOption.reverse ? v1 - v2 : v2 - v1
      }
      if(field == 'status'){
        var arr = ['Inactive', 'Verifying', 'Active']
        var i1 = arr.indexOf(v1)
        var i2 = arr.indexOf(v2)
        return this.sortOption.reverse ? i2 - i1 : i1 - i2
      }
      return 0
    }
  },
  mounted () {
    this.sortOption = this.$store.state.user.sortOption
    this.getUsers()
  }
}
</script>

<style lang="scss" scoped>

.users-container {
  margin-top: 30px;
}

.user-table {
  margin: auto;
}

.clickable {
  cursor: pointer;
}

.asc-icon {
  position: relative;
  top: 5px;
}

</style>
