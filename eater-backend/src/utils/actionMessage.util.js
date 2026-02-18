function getActionMessage(action, entity = '') {
    const act = (action || '').toLowerCase();
    const verbMap = { create: 'Create', update: 'Update', delete: 'Delete' };
    const verb = verbMap[act] || 'Done';
    const suffix = act === 'create' ? 'successfully!' : 'successfully';
    return entity ? `${verb} ${entity} ${suffix}` : `${verb} ${suffix}`;
}

module.exports = { getActionMessage };