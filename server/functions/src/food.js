const axios = require('axios');

/**
 * Retrieve Edamam food data
 */
const _appId = '47b2ce40';
const _appKey = '6baa72019f5be55b501442052edf134b';
const _edamamUrl = 'http://api.edamam.com/api/food-database/v2/parser';

exports.edamamFoodSearch = async (input, context) => {
  const query = input.query;
  const edamamQuery = await axios.create({
    baseURL: _edamamUrl,
    params: {
      app_id: _appId,
      app_key: _appKey,
      ingr: query,
    },
  });
  const { status, data } = await edamamQuery.get();
  return { status, data };
};
