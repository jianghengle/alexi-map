<template>
  <div class="login-page">
    <div class="container">
      <div class="welcome">User Profile</div>

      <div class="spinner-container" v-if="waiting">
        <icon name="spinner" class="icon is-medium fa-spin"></icon>
      </div>

      <div v-if="error0" class="notification is-danger login-text">
        <button class="delete" @click="error0=''"></button>
        {{error0}}
      </div>

      <div class="field">
        <label class="label">Email</label>
        <div class="control has-icons-left">
          <input class="input login-text" type="text" placeholder="Email Address" v-model="email" readonly>
          <span class="icon is-small is-left">
            <icon name="envelope"></icon>
          </span>
        </div>
      </div>

      <div class="field">
        <label class="label">First Name</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="First Name" v-model="firstName">
        </div>
      </div>

      <div class="field">
        <label class="label">Last Name</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Last Name" v-model="lastName">
        </div>
      </div>

      <div class="field">
        <label class="label">Country</label>
        <div class="control">
          <div class="select">
            <select v-model="country">
              <option v-for="c in countryList">{{c}}</option>
            </select>
          </div>
        </div>
      </div>

      <div class="field" v-if="country == 'United States of America'">
        <label class="label">State</label>
        <div class="control">
          <div class="select">
            <select v-model="state">
              <option v-for="s in stateList">{{s}}</option>
            </select>
          </div>
        </div>
      </div>

      <div class="field">
        <label class="label">City</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="City" v-model="city">
        </div>
      </div>

      <div class="field">
        <label class="label">Affiliation</label>
        <div class="control">
          <div class="select">
            <select v-model="affiliationSelected">
              <option v-for="a in affiliationList">{{a}}</option>
            </select>
          </div>
        </div>
      </div>

      <div class="field" v-if="affiliationSelected == 'Other'">
        <label class="label">Other Affiliation</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Affiliation" v-model="otherAffiliation">
        </div>
      </div>

      <div class="field">
        <label class="label">Employer (optional)</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Employer" v-model="employer">
        </div>
      </div>

      <div class="field">
        <label class="label">Job Title (optional)</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Job Title" v-model="title">
        </div>
      </div>

      <div class="field">
        <label class="label">Primary Purpose for accessing GloDET data</label>
        <div class="control">
          <div class="select">
            <select v-model="purposeSelected">
              <option v-for="p in purposeList">{{p}}</option>
            </select>
          </div>
        </div>
      </div>

      <div class="field" v-if="purposeSelected == 'Other'">
        <label class="label">Other Purpose</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Purpose" v-model="otherPurpose">
        </div>
      </div>

      <div class="field">
        <label class="label">How did you hear about us?</label>
        <div class="control">
          <div class="select">
            <select v-model="hearFromSelected">
              <option v-for="h in hearFromList">{{h}}</option>
            </select>
          </div>
        </div>
      </div>

      <div class="field" v-if="hearFromSelected == 'Other'">
        <label class="label">Other Source</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Where Else" v-model="otherHearFrom">
        </div>
      </div>

      <div v-if="error1" class="notification is-danger login-text">
        <button class="delete" @click="error1=''"></button>
        {{error1}}
      </div>

      <div v-if="success1" class="notification is-success login-text">
        <button class="delete" @click="success1=''"></button>
        {{success1}}
      </div>

      <div class="field is-grouped">
        <div class="control">
          <button class="button is-link" :class="{'is-loading': waiting}" :disabled="!canUpdateProfile" @click="updateProfile">Update Profile</button>
        </div>
      </div>

      <br/>

      <div class="welcome">Change Password</div>
      <div class="field">
        <label class="label">Old Password</label>
        <div class="control has-icons-left">
          <input class="input login-text" type="password" placeholder="Old password" v-model="oldPassword">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </div>
      </div>

      <div class="field">
        <label class="label">New Password</label>
        <div class="control has-icons-left">
          <input class="input login-text" :class="{'is-danger': !passwordValid}" type="password" placeholder="New password" v-model="password">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </div>
        <p v-if="!passwordValid" class="help is-danger">New password must be at least 6 character.</p>
      </div>

      <div class="field">
        <label class="label">Confirm New Password</label>
        <div class="control has-icons-left">
          <input class="input login-text" :class="{'is-danger': !passwordsMatch}" type="password" placeholder="Retype new password" v-model="passwordAgain">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </div>
        <p v-if="!passwordsMatch" class="help is-danger">Retyped password must match the original one.</p>
      </div>

      <div v-if="error2" class="notification is-danger login-text">
        <button class="delete" @click="error2=''"></button>
        {{error2}}
      </div>

      <div v-if="success2" class="notification is-success login-text">
        <button class="delete" @click="success2=''"></button>
        {{success2}}
      </div>

      <div class="field is-grouped">
        <div class="control">
          <button class="button is-link" :class="{'is-loading': waiting}" :disabled="!passwordValid || !passwordsMatch" @click="changePassword">Change Password</button>
        </div>
      </div>


    </div>
  </div>
</template>

<script>
import Vue from 'vue'

var countryList = ["Afghanistan","Albania","Algeria","Andorra","Angola","Anguilla","Antigua &amp; Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia","Bosnia &amp; Herzegovina","Botswana","Brazil","British Virgin Islands","Brunei","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Cape Verde","Cayman Islands","Chad","Chile","China","Colombia","Congo","Cook Islands","Costa Rica","Cote D Ivoire","Croatia","Cruise Ship","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Estonia","Ethiopia","Falkland Islands","Faroe Islands","Fiji","Finland","France","French Polynesia","French West Indies","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guam","Guatemala","Guernsey","Guinea","Guinea Bissau","Guyana","Haiti","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kuwait","Kyrgyz Republic","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macau","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Namibia","Nepal","Netherlands","Netherlands Antilles","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Puerto Rico","Qatar","Reunion","Romania","Russia","Rwanda","Saint Pierre &amp; Miquelon","Samoa","San Marino","Satellite","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","South Africa","South Korea","Spain","Sri Lanka","St Kitts &amp; Nevis","St Lucia","St Vincent","St. Lucia","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Tajikistan","Tanzania","Thailand","Timor L'Este","Togo","Tonga","Trinidad &amp; Tobago","Tunisia","Turkey","Turkmenistan","Turks &amp; Caicos","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States of America","Uruguay","Uzbekistan","Venezuela","Vietnam","Virgin Islands (US)","Yemen","Zambia","Zimbabwe"]

var stateList = ['Alabama','Alaska','American Samoa','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','District of Columbia','Federated States of Micronesia','Florida','Georgia','Guam','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Marshall Islands','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Northern Mariana Islands','Ohio','Oklahoma','Oregon','Palau','Pennsylvania','Puerto Rico','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virgin Island','Virginia','Washington','West Virginia','Wisconsin','Wyoming']

var affiliationList = ['University/Research Institution', 'Government Agency', 'Non-governmental Organization/Non-profit', 'Private Sector/For-profit', 'Agricultural Producer/Farmer', 'Other']

var purposeList = ['Scholarly Research/Publication in Academic Journal', 'Establishing/Administering Public Policy', 'Information Dissemination/Public Communications', 'Agricultural/Field Management', 'Drought Monitoring', 'Consulting/For-profit', 'Other']

var hearFromList = ['Internet search', 'Facebook', 'LinkedIn', 'Twitter', 'Robert B. Daugherty Water for Food Global Institute website', 'National Drought Mitigation Center website', 'ICBA website', 'Other' ]


export default {
  name: 'alexi-profile',
  data () {
    return {
      error0: '',
      error1: '',
      success1: '',
      error2: '',
      success2: '',
      waiting: false,
      email: '',
      firstName: '',
      lastName: '',
      countryList: countryList,
      country: 'United States of America',
      stateList: stateList,
      state: 'Nebraska',
      city: '',
      affiliationList: affiliationList,
      affiliationSelected: 'University/Research Institution',
      otherAffiliation: '',
      employer: '',
      title: '',
      purposeList: purposeList,
      purposeSelected: 'Scholarly Research/Publication in Academic Journal',
      otherPurpose: '',
      hearFromList: hearFromList,
      hearFromSelected: 'Internet search',
      otherHearFrom: '',
      profile: null,
      oldPassword: '',
      password: '',
      passwordAgain: ''
    }
  },
  computed: {
    passwordValid () {
      return this.password.length >= 6
    },
    passwordsMatch () {
      return this.password == this.passwordAgain
    },
    canUpdateProfile () {
      var p = this.collectProfile()
      if (p.firstName && p.lastName && p.affiliation && p.purpose && p.hearFrom){
        return p.firstName != this.profile.firstName
          || p.lastName != this.profile.lastName
          || p.country != this.profile.country
          || p.state != this.profile.state
          || p.city != this.profile.city
          || p.affiliation != this.profile.affiliation
          || p.employer != this.profile.employer
          || p.title != this.profile.title
          || p.purpose != this.profile.purpose
          || p.hearFrom != this.profile.hearFrom
      }
      return false
    }
  },
  methods: {
    updateProfile () {
      if(!this.canUpdateProfile)
        return
      this.waiting = true
      var message = this.collectProfile()
      this.$http.post(xHTTPx + '/update_user_profile', message).then(response => {
        this.profile = response.body
        this.applyProfile()
        this.$store.commit('user/setName', this.firstName)
        this.success1 = 'Profile update succeed!'
        this.error1 = ''
        this.waiting = false
      }, response => {
        this.error1 = 'Failed to update profile: ' + JSON.stringify(response.body)
        this.success1 = ''
        this.waiting = false
      })
    },
    changePassword () {
      if(!this.passwordValid || !this.passwordsMatch)
        return
      this.waiting = true
      var message = {
        oldPassword: this.oldPassword,
        newPassword: this.password
      }
      this.$http.post(xHTTPx + '/update_user_password', message).then(response => {
        this.waiting = false
        this.oldPassword = ''
        this.password = ''
        this.passwordAgain = ''
        this.error2 = ''
        this.success2 = 'Password change succeed!'
      }, response => {
        this.error2 = 'Failed to update password: ' + JSON.stringify(response.body)
        this.success2 = ''
        this.waiting = false
      })
    },
    applyProfile () {
      this.email = this.profile.email
      this.firstName = this.profile.firstName
      this.lastName = this.profile.lastName
      this.country = this.profile.country
      this.state = this.profile.state
      this.city = this.profile.city
      var affiliation = this.profile.affiliation
      if(this.affiliationList.indexOf(affiliation) > -1 && affiliation != 'Other'){
        this.affiliationSelected = affiliation
        this.otherAffiliation = ''
      }else{
        this.affiliationSelected = 'Other'
        this.otherAffiliation = affiliation
      }
      this.employer = this.profile.employer
      this.title = this.profile.title
      var purpose = this.profile.purpose
      if(this.purposeList.indexOf(purpose) > -1 && purpose != 'Other'){
        this.purposeSelected = purpose
        this.otherPurpose = ''
      }else{
        this.purposeSelected = 'Other'
        this.otherPurpose = purpose
      }
      var hearFrom = this.profile.hearFrom
      if(this.hearFromList.indexOf(hearFrom) > -1 && hearFrom != 'Other'){
        this.hearFromSelected = hearFrom
        this.otherHearFrom = ''
      }else{
        this.hearFromSelected = 'Other'
        this.otherHearFrom = hearFrom
      }
    },
    collectProfile () {
      var profile = {
        firstName: this.firstName,
        lastName: this.lastName,
        country: this.country,
        state: this.country == 'United States of America' ? this.state : '',
        city: this.city,
        affiliation: this.affiliationSelected == 'Other' ? this.otherAffiliation : this.affiliationSelected,
        employer: this.employer,
        title: this.title,
        purpose: this.purposeSelected == 'Other' ? this.otherPurpose : this.purposeSelected,
        hearFrom: this.hearFromSelected == 'Other' ? this.otherHearFrom : this.hearFromSelected
      }
      return profile
    },
    getProfile () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_user_profile').then((response) => {
        var resp = response.body
        this.profile = resp
        this.applyProfile()
        this.waiting = false
      }, (response) => {
        this.error0 = 'Failed to get user profile: ' + JSON.stringify(response.body)
        this.waiting = false
      })
    }
  },
  mounted () {
    this.getProfile()
  }
}
</script>

<style lang="scss" scoped>

.login-page {
  padding: 20px;
  margin-top: 50px;
}

.welcome {
  padding-top: 30px;
  padding-bottom: 15px;
  font-weight: bold;
  text-decoration: underline;
}

.login-text {
  max-width: 800px;
}
</style>
