/*
 * This file is auto-generated by simulator_c.ml.
 * Do not modify it directly!
 */

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>

#include "memory.h"

const long long nbSteps = $NB_STEPS$;

typedef struct gate_t
{
    word_t (*fct)();
    word_t value;
    bool is_calculated;
} gate_t;

static inline void gate_init(gate_t *gate) {
    gate->is_calculated = false;
    gate->value = 0;
}

static inline word_t gate_calc(gate_t *gate)
{
    if (!gate->is_calculated)
    {
        gate->value = gate->fct();
        gate->is_calculated = true;
    }

    return gate->value;
}

typedef struct reg_t
{
    uint32_t (*fct)();
    word_t value;
    word_t old_value;
    bool is_calculated;
} reg_gate_t;

static inline void reg_init(reg_gate_t *gate) {
    gate->is_calculated = false;
    gate->value = 0;
    gate->old_value = gate->value;
}

static inline word_t reg_calc(reg_gate_t *gate)
{
    if (!gate->is_calculated)
    {
        gate->value = gate->fct();
        gate->is_calculated = true;
    }

    return gate->value;
}

static inline void ram_write(ram_t *ram, int write_enabled, addr_t addr, word_t value)
{
    if (write_enabled)
        ram_set(ram, addr, value);
}

$MEM_DEF$

$GATE_DEF$

$FCT_DEF$

int main()
{
    $FCT_SET$

    $READ_ROM$

    for (unsigned long long iStep = 0; iStep != nbSteps; iStep++)
    {
        printf("Step %lld:\n", iStep + 1);
        $CYCLE$
    }
}