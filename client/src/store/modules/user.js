
// initial state
export const state = {
  token: localStorage.getItem('token'),
  email: localStorage.getItem('email'),
  name: localStorage.getItem('name')
}

// mutations
export const mutations = {
  setToken (state, token) {
    state.token = token
  },

  setEmail (state, email) {
    state.email = email
  },

  setName (state, name) {
    state.name = name
    localStorage.setItem('name', name)
  },

  reset (state) {
    state.token = null
    state.email = null
    state.name = null
    localStorage.removeItem('token')
    localStorage.removeItem('email')
    localStorage.removeItem('name')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
