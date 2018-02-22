<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Save Setting</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
          <div v-if="error" class="notification is-danger">
            <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Save to setting</label>
            <p class="control">
              <span class="select">
                <select v-model="settingId">
                  <option v-for="option in settingOptions" v-bind:value="option.id">
                    {{ option.name }}
                  </option>
                </select>
              </span>
            </p>
          </div>
          <div class="field" v-show="settingId == ''">
            <label class="label">New Setting Name</label>
            <p class="control">
              <input class="input" type="text" v-model="settingName">
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger" :class="{'is-loading': waiting}" @click="saveSetting">Save</a>
          <a class="button button-right" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>
export default {
  name: 'save-setting-modal',
  props: ['opened', 'settings', 'setting'],
  data () {
    return {
      error: '',
      waiting: false,
      settingId: '',
      settingName: ''
    }
  },
  computed: {
    settingOptions () {
      var options = []
      if(this.settings){
        options = this.settings.slice()
      }
      options.push({name: '(Create New Setting)', id: ''})
      return options
    },
    settingMap () {
      var settingMap = {}
      if(this.settings.length){
        this.settings.forEach(function(s){
          settingMap[s.id] = s
        })
      }
      return settingMap
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.error = ''
        this.waiting = false
        this.settingId = ''
        if(this.settings.length){
          this.settingId = this.settings[0].id
        }
        this.settingName = ''
      }
    },
  },
  methods: {
    close(){
      this.$emit('close-save-setting-modal', false)
    },
    saveSetting(){
      this.waiting = true
      var message = {
        id: this.settingId,
        name: this.settingId === '' ? this.settingName : this.settingMap[this.settingId].name,
        isDefault: this.settingId === '' ? false : this.settingMap[this.settingId].isDefault,
        mapHeight: this.setting.mapHeight,
        mapCenter: this.setting.mapCenter,
        mapZoom: this.setting.mapZoom,
        mapOption: this.setting.mapOption,
        imageOption: this.setting.imageOption,
        tileOpacity: this.setting.tileOpacity,
        selection: this.setting.selection,
        tileSize: this.setting.tileSize
      }
      this.$http.post(xHTTPx + '/save_user_setting', message).then(response => {
        var resp = response.body
        this.waiting= false
        this.$emit('close-save-setting-modal', true)
      }, response => {
        this.error = 'Failed to save setting: ' + JSON.stringify(response.body)
        this.waiting= false
      })
    }
  }
}
</script>

<style lang="scss" scoped>

.modal-body {
  color: black;
  font-size: 16px;
}

.button-right {
  position: absolute;
  right: 0px;
  margin-right: 20px;
}
</style>