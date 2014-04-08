function ddg_spice_is_it_up(response) {
    "use strict";

    response['status_code'] = (response['status_code'] === 1);

    Spice.add({
        data             : response,
        sourceUrl       : 'http://isitup.org/' + response['domain'],
        sourceName      : 'Is it up?',
        templates: {
            item: Spice.is_it_up.is_it_up,
            detail: Spice.is_it_up.is_it_up
        },
    });
}
