<template>
  <div class="settings-page">
    <div class="container">
      <div class="spinner-container" v-if="waiting">
        <icon name="spinner" class="icon is-medium fa-spin"></icon>
      </div>
      <div v-if="error" class="notification is-danger">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      <div class="settings-page-title">All Settings</div>
      <div class="tabs">
        <ul>
          <li v-for="setting in settings"
            :key="setting.id"
            :class="{'is-active': setting.id == activeSettingId}">
            <a @click="activeSettingId = setting.id">{{setting.name}}<span v-if="setting.isDefault">&nbsp;(default)</span></a>
          </li>
        </ul>
      </div>
      <setting-tab :setting="activeSetting" @setting-updated="getSettings"></setting-tab>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import SettingTab from './SettingTab'

export default {
  name: 'alexi-settings',
  components: {
    SettingTab
  },
  data () {
    return {
      error: '',
      waiting: false,
      settings: [],
      activeSettingId: null
    }
  },
  computed: {
    settingMap () {
      var settingMap = {}
      if(this.settings.length){
        this.settings.forEach(function(s){
          settingMap[s.id] = s
        })
      }
      return settingMap
    },
    activeSetting () {
      return this.settingMap[this.activeSettingId]
    }
  },
  methods: {
    getSettings () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_user_settings').then((response) => {
        var resp = response.body
        this.settings = resp
        if(!this.settingMap[this.activeSettingId] && this.settings.length){
          this.activeSettingId = this.settings[0].id
        }
        this.waiting = false
      }, (response) => {
        console.log('failed to get latest tiles')
        this.error = 'Failed to get user settings: ' + JSON.stringify(response.body)
        this.waiting = false
      })
    }
  },
  mounted () {
    this.getSettings()
  }
}
</script>

<style lang="scss" scoped>

.settings-page-title {
  padding-top: 30px;
  padding-bottom: 15px;
  font-weight: bold;
}

.settings-page {
  padding-bottom: 100px;
}

</style>
