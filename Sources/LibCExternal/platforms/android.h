#pragma once

#include <unistd.h>

char **environ_wrapper() {
    return environ;
}
