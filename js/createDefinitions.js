
function createDefinitions(value) {

    function is_int(value) {
        if ((undefined === value) || (null === value)) {
            return false;
        }
        return value % 1 == 0;
    }

    if (is_int(value)) {
        return {
            expected_effects: [
                {effect_type: "beastie", action: "beastie" },   //дикое животное для всех
                {effect_type: "water", max_amount: 0.8, min_amount: 0.2, multiplier: 1, distance_x: 1, distance_y: 1, views: [5,6,7], action: "accelerate" },   //вода для грядок
                {effect_type: "road", distance_x: 0, distance_y: 0, views: [1], min_amount: 0.1, max_amount: 0.2, multiplier: 1, action: "accelerate" }
            ]
        };
    } else {
        return { error: "Not integer value" };
    }
}