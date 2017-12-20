
// initial state
export const state = {
  token: localStorage.getItem('token'),
  email: localStorage.getItem('email')
}

// mutations
export const mutations = {
  setToken (state, token) {
    state.token = token
  },

  setEmail (state, email) {
    state.email = email
  },

  reset (state) {
    state.token = null
    state.email = null
    localStorage.removeItem('token')
    localStorage.removeItem('email')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
