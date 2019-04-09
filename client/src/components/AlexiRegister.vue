<template>
  <div class="login-page">
    <div class="container">
      <div class="welcome">
        Thank you for accessing the GloDET data viewer!<br/> 
        In order to download global daily evapotranspiration datasets, you must sign-up for a user account.<br/>
        Please complete the registration information below, and click Submit.
      </div>

      <div class="notification is-danger">
        The GloDET data viewer is currently still under development.  New users who are not actively involved in the development will not be registered at this time.  For questions, please contact Lacey Bodnar, DWFI Project Manager, at <a href="mailto:lbodnar@nebraska.edu">lbodnar@nebraska.edu</a>.
      </div>

      <div class="field">
        <label class="label">Email</label>
        <div class="control has-icons-left">
          <input class="input login-text" :class="{'is-danger': !emailValid}" type="text" placeholder="Email Address" v-model="email" v-focus>
          <span class="icon is-small is-left">
            <icon name="envelope"></icon>
          </span>
        </div>
        <p v-if="!emailValid" class="help is-danger">Must be a valid email address</p>
      </div>

      <div class="field">
        <label class="label">Password</label>
        <div class="control has-icons-left">
          <input class="input login-text" :class="{'is-danger': !passwordValid}" type="password" placeholder="Password" v-model="password">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </div>
        <p v-if="!passwordValid" class="help is-danger">Password must be at least 6 character.</p>
      </div>

      <div class="field">
        <label class="label">Confirm Password</label>
        <div class="control has-icons-left">
          <input class="input login-text" :class="{'is-danger': !passwordsMatch}" type="password" placeholder="Retype Password" v-model="passwordAgain">
          <span class="icon is-small is-left">
            <icon name="key"></icon>
          </span>
        </div>
        <p v-if="!passwordsMatch" class="help is-danger">Retyped password must match the original one.</p>
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
        <label class="label">Employer</label>
        <div class="control">
          <input class="input login-text" type="text" placeholder="Employer" v-model="employer">
        </div>
      </div>

      <div class="field">
        <label class="label">Job Title</label>
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

      <div class="field">
        <div class="control">
          <label class="checkbox">
            <input type="checkbox" v-model="agreeTerms">
            Click to agree to the <a href="static/GloDET Terms and Conditions_FINAL.pdf" target="_blank">terms and conditions</a> for use of the GloDET datasets
          </label>
        </div>
      </div>

      <div class="field">
        <div class="control">
          <label class="checkbox">
            <input type="checkbox" v-model="subscribeWFI">
            Sign up for emails from the <a href="http://waterforfood.nebraska.edu/" target="_blank">Robert B. Daugherty Water for Food Global Institute at the University of Nebraska</a>
          </label>
        </div>
      </div>

      <div class="field">
        <div class="control">
          <label class="checkbox">
            <input type="checkbox" v-model="subscribeNDMC">
            Sign up for emails from the <a href="http://drought.unl.edu" target="_blank">National Drought Mitigation Center at the University of Nebraska</a>
          </label>
        </div>
      </div>

      <div v-if="error" class="notification is-danger login-text">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>

      <div v-if="success" class="notification is-success login-text">
        <button class="delete" @click="success=false"></button>
        You have successfully registered your account! The Daugherty Water for Food Global Institute will review your registration information and respond to your request within 24 hours.
      </div>

      <div class="field is-grouped">
        <div class="control">
          <button class="button is-primary" :class="{'is-loading': waiting}" :disabled="!canSubmit" @click="register">Submit</button>
        </div>
        <div class="control">
          <button class="button is-text"><router-link :to="'/login'">Back to Login</router-link></button>
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

var purposeList = ['Scholarly Research/Publication in Academic Journal', 'Establishing/Administering Public Policy', 'Information Dissemination/Public Communications', 'Agricultural/Field Water Management', 'Drought Monitoring', 'Consulting/For-profit', 'Other']

var hearFromList = ['Internet search', 'Facebook', 'LinkedIn', 'Twitter', 'Robert B. Daugherty Water for Food Global Institute website', 'National Drought Mitigation Center website', 'ICBA website', 'Other' ]

const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

export default {
  name: 'alexi-register',
  data () {
    return {
      error: '',
      success: false,
      waiting: false,
      email: '',
      password: '',
      passwordAgain: '',
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
      agreeTerms: false,
      subscribeWFI: false,
      subscribeNDMC: false
    }
  },
  computed: {
    emailValid () {
      return emailRegex.test(this.email)
    },
    passwordValid () {
      return this.password.length >= 6
    },
    passwordsMatch () {
      return this.password == this.passwordAgain
    },
    affiliation () {
      if(this.affiliationSelected != 'Other')
        return this.affiliationSelected
      return this.otherAffiliation
    },
    purpose () {
      if(this.purposeSelected != 'Other')
        return this.purposeSelected
      return this.otherPurpose
    },
    hearFrom () {
      if(this.hearFromSelected != 'Other')
        return this.hearFromSelected
      return this.otherHearFrom
    },
    canSubmit () {
      return this.emailValid && this.passwordValid && this.passwordsMatch
        && this.firstName.length && this.lastName.length && this.city
        && this.affiliation.length && this.employer.length && this.title.length
        && this.purpose.length && this.hearFrom.length
        && this.agreeTerms
    }
  },
  watch: {
    agreeTerms: function (val) {
      if(val){
        var link = document.createElement("a");
        link.target = '_blank';
        link.href = 'static/GloDET Terms and Conditions_FINAL.pdf';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
    },
  },
  methods: {
    register () {
      if(!this.canSubmit)
        return
      this.waiting = true
      var message = {
        email: this.email,
        password: this.password,
        firstName: this.firstName,
        lastName: this.lastName,
        country: this.country,
        state: this.country == 'United States of America' ? this.state : '',
        city: this.city,
        affiliation: this.affiliation,
        employer: this.employer,
        title: this.title,
        purpose: this.purpose,
        hearFrom: this.hearFrom,
        subscribeWFI: this.subscribeWFI,
        subscribeNDMC: this.subscribeNDMC
      }
      this.$http.post(xHTTPx + '/register', message).then(response => {
        var ok = response.body.ok
        if(ok){
          this.success = true
          this.error = ''
        }else{
          this.success = false
          this.error = 'Failed to register user: ' + JSON.stringify(response.body)
        }
        this.waiting = false
      }, response => {
        this.success = false
        this.error = 'Failed to register user: ' + JSON.stringify(response.body)
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
  max-width: 800px;
}
</style>
