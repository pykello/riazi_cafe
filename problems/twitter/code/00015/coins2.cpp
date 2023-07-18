#include <iostream>
using namespace std;

const int INF = INT32_MAX;

const int TYPE_COUNT = 10;

// We will choose coins_of_type[i] machines & put "i" coins of each of these
// machines in the first weighing.
int coins_of_type[TYPE_COUNT];

int coins_needed()
{
    int first_weighing = 0;
    for (int i = 0; i < TYPE_COUNT; i++)
        first_weighing += i * coins_of_type[i];

    int result = 0;
    for (int i = 0; i < TYPE_COUNT; i++) {
        int additional_coins_in_second_weighing = 0;
        for (int j = 0; j < coins_of_type[i]; j++)
            if (j > i)
                additional_coins_in_second_weighing += j - i;
        result = max(result, first_weighing + additional_coins_in_second_weighing);
    }
    return result;
}

int recurse(int type_idx, int remaining_machines) {
    if (type_idx == TYPE_COUNT) {
        if (remaining_machines)
            return INF;

        return coins_needed();
    }

    int result = INF;
    for (int i = 0; i <= remaining_machines; i++)
    {
        coins_of_type[type_idx] = i;
        result = min(result, recurse(type_idx + 1, remaining_machines - i));
    }

    return result;
}

int main() {
    cout << recurse(0, 10) << endl;
    return 0;
}