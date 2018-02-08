<template>
  <div class="container">
    <div class="field">
      <label class="label">Name</label>
      <p class="control">
        <input class="input text-field" type="text" v-model="name">
      </p>
    </div>

    <div class="field">
      <p class="control">
        <label class="checkbox">
          <input type="checkbox" v-model="isDefault" :disabled="setting && setting.isDefault">
          Is Default
        </label>
      </p>
    </div>

    <div class="field">
      <label class="label">Map Height (pixel)</label>
      <p class="control">
        <input class="input text-field" type="number" step="20" v-model.number="mapHeight">
      </p>
    </div>

    <div class="field">
      <label class="label">Map Center (Latitude, Longitude)</label>
      <p class="control">
        <input class="input text-field" type="text" v-model="mapCenter">
      </p>
    </div>

    <div class="field">
      <label class="label">Map Zoom Level (0 ~ 19)</label>
      <p class="control">
        <input class="input text-field" type="number" min="0" max="19" step="1" v-model.number="mapZoom">
      </p>
    </div>

    <div class="field">
      <label class="label">Selection (North, South, East, West)</label>
      <p class="control">
        <input class="input text-field" type="text" v-model="selection">
      </p>
    </div>

    <div class="field">
      <label class="label">Tile Opacity (0 ~ 1)</label>
      <p class="control">
        <input class="input text-field" type="number" min="0" max="1" step="0.1" v-model.number="tileOpacity">
      </p>
    </div>

    <div class="field">
      <label class="label">Tile Size (pixel)</label>
      <p class="control">
        <input class="input text-field" type="number" step="10" v-model.number="tileSize">
      </p>
    </div>

    <div class="field">
      <p class="control">
        <label class="checkbox">
          <input type="checkbox" v-model="showGrid">
          Show Grid
        </label>
      </p>
    </div>

    <div class="field">
      <p class="control">
        <label class="checkbox">
          <input type="checkbox" v-model="showSelection">
          Show Selection
        </label>
      </p>
    </div>

    <div class="field is-grouped">
      <div class="control">
        <button class="button is-link" :class="{'is-loading': waiting}" :disabled="!changed" @click="updateSetting">Update</button>
      </div>
      <div class="control">
        <button class="button is-text" v-if="setting && !setting.isDefault" :class="{'is-loading': waiting}" :disabled="changed" @click="deleteSetting">Delete</button>
      </div>
    </div>

    <confirm-modal
      :opened="confirmModal.opened"
      :title="confirmModal.title"
      :message="confirmModal.message"
      :confirm-button="confirmModal.confirmButton"
      @close-confirm-modal="closeConfirmModal">
    </confirm-modal>
  </div>
</template>

<script>
import Vue from 'vue'
import ConfirmModal from './modals/ConfirmModal'

export default {
  name: 'setting-tab',
  components: {
    ConfirmModal
  },
  props: ['setting'],
  data () {
    return {
      error: '',
      waiting: false,
      isDefault: false,
      name: '',
      mapHeight: 600,
      mapCenter: "22.5, 22.5",
      mapZoom: 3,
      showGrid: true,
      showSelection: true,
      tileOpacity: 0.6,
      selection: '35, 10, 35, 10',
      tileSize: 200,
      confirmModal: {
        opened: false,
        message: '',
        button: '',
        context: null
      },
    }
  },
  computed: {
    changed () {
      if(!this.setting)
        return false
      return this.isDefault != this.setting.isDefault
        || this.name !=this.setting.name.trim()
        || this.mapHeight !=this.setting.mapHeight
        || this.mapCenter != this.setting.mapCenter
        || this.mapZoom != this.setting.mapZoom
        || this.showGrid != this.setting.showGrid
        || this.showSelection != this.setting.showSelection
        || this.tileOpacity != this.setting.tileOpacity
        || this.selection != this.setting.selection
        || this.tileSize != this.setting.tileSize
    }
  },
  watch: {
    setting: function (val) {
      if(val){
        this.isDefault = val.isDefault
        this.name = val.name
        this.mapHeight = val.mapHeight
        this.mapCenter = val.mapCenter
        this.mapZoom = val.mapZoom
        this.showGrid = val.showGrid
        this.showSelection = val.showSelection
        this.tileOpacity = val.tileOpacity
        this.selection = val.selection
        this.tileSize = val.tileSize
      }
    },
  },
  methods: {
    updateSetting () {
      this.waiting = true
      var message = {
        id: this.setting.id,
        name: this.name.trim(),
        isDefault: this.isDefault,
        mapHeight: this.mapHeight,
        mapCenter: this.mapCenter.trim(),
        mapZoom: this.mapZoom,
        showGrid: this.showGrid,
        showSelection: this.showSelection,
        tileOpacity: this.tileOpacity,
        selection: this.selection.trim(),
        tileSize: this.tileSize
      }
      this.$http.post(xHTTPx + '/save_user_setting', message).then(response => {
        this.waiting= false
        this.$emit('setting-updated', true)
      }, response => {
        this.error = 'Failed to update setting: ' + JSON.stringify(response.body)
        this.waiting= false
      })
    },
    deleteSetting () {
      var title = 'Delete Setting'
      var message = 'Are you sure to delete this setting!'
      var confirmButton = 'Yes, I am sure'
      var context = {callback: this.deleteSettingConfirmed, args: []}
      this.openConfirmModal(title, message, confirmButton, context)
    },
    deleteSettingConfirmed () {
      this.waiting = true
      var message = { id: this.setting.id }
      this.$http.post(xHTTPx + '/delete_user_setting', message).then(response => {
        this.waiting= false
        this.$emit('setting-updated', true)
      }, response => {
        this.error = 'Failed to delete setting: ' + JSON.stringify(response.body)
        this.waiting= false
      })
    },
    openConfirmModal (title, message, confirmButton, context) {
      this.confirmModal.title = title
      this.confirmModal.message = message
      this.confirmModal.confirmButton = confirmButton
      this.confirmModal.context = context
      this.confirmModal.opened = true
    },
    closeConfirmModal (result) {
      this.confirmModal.title = ''
      this.confirmModal.message = ''
      this.confirmModal.confirmButton = ''
      this.confirmModal.opened = false
      if(result && this.confirmModal.context){
        var context = this.confirmModal.context
        if(context.callback){
            context.callback.apply(this, context.args)
        }
      }
      this.confirmModal.context = null
    },
  }
}
</script>

<style lang="scss" scoped>

.settings-page-title {
  padding-top: 30px;
  padding-bottom: 15px;
  font-weight: bold;
}

.text-field {
  max-width: 800px;
}
</style>
