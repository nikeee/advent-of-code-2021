// Compile:
//     gcc -O4 -std=c11 -Wall -Wextra main.c -o main
// Run:
//     ./main < input.txt

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>

#define BOARD_SIZE 5
#define BOARD_NUMBER_COUNT (BOARD_SIZE * BOARD_SIZE)

typedef int8_t number;

void mark_number_as_drawn(number *board, number n)
{
    for (size_t i = 0; i < BOARD_NUMBER_COUNT; ++i)
        if (board[i] == n)
            board[i] = -1;
}

/**
 * This function is full of UB :)
 */
bool board_has_won(number *board)
{
    const uint64_t row_pattern = 0x000000ffffffffffull; // little endian
    for (size_t row_offset = 0; row_offset < BOARD_NUMBER_COUNT; row_offset += BOARD_SIZE)
    {
        uint64_t row = *((uint64_t *)&board[row_offset]);
        if ((row & row_pattern) == row_pattern)
            return true;
    }

    // if we'd have 200 bit integers, we could solve this by using a bit mask and shifting 5 times by 8 bits instead
    for (size_t column_index = 0; column_index < BOARD_SIZE; ++column_index)
    {
        bool all_in_column_are_marked = true;
        for (size_t row_index = 0; row_index < BOARD_SIZE; ++row_index)
        {
            if (board[column_index + row_index * BOARD_SIZE] >= 0)
            {
                all_in_column_are_marked = false;
                break;
            }
        }
        if (all_in_column_are_marked)
            return true;
    }
    return false;
}

uint32_t compute_board_score(number *board, number last_drawn_number)
{
    uint32_t sum_of_unmarked = 0;
    for (int i = 0; i < BOARD_NUMBER_COUNT; ++i)
    {
        number v = board[i];
        if (v > 0)
            sum_of_unmarked += (uint8_t)v;
    }

    return sum_of_unmarked * (uint8_t)last_drawn_number;
}

int main()
{
    int exit_code = EXIT_SUCCESS;

    number *drawn_numbers = calloc(100, sizeof(number));
    if (drawn_numbers == NULL)
    {
        exit_code = EXIT_FAILURE;
        goto fail_0;
    }

    size_t drawn_numbers_count = 0;
    do
    {
        int read = scanf("%" SCNi8, &drawn_numbers[drawn_numbers_count]);
        if (read != 1)
        {
            exit_code = EXIT_FAILURE;
            goto fail_1;
        }

        ++drawn_numbers_count;
    } while (getchar() == ',');

    number *boards[100] = {NULL};
    size_t boards_count = 0;

    bool all_boards_read = false;
    while (true)
    {
        number *current_board = calloc(BOARD_NUMBER_COUNT, sizeof(number));
        if (current_board == NULL)
        {
            exit_code = EXIT_FAILURE;
            goto fail_2;
        }

        for (size_t i = 0; i < BOARD_NUMBER_COUNT; ++i)
        {
            int read = scanf("%" SCNi8 "\n", &current_board[i]);
            if (read == EOF)
            {
                all_boards_read = true;
                break;
            }
        }

        if (!all_boards_read)
        {
            boards[boards_count] = current_board;
            ++boards_count;
        }
        else
        {
            break;
        }
    }

    size_t finished_boards = 0;

    for (size_t number_index = 0; number_index < drawn_numbers_count; ++number_index)
    {
        number n = drawn_numbers[number_index];

        for (size_t board_index = 0; board_index < boards_count; ++board_index)
        {
            number *board = boards[board_index];
            if (board == NULL)
                continue;

            mark_number_as_drawn(board, n);

            // Small micro optimization: We can only have a winning board if there were at least BOARD_SIZE numbers drawn
            if (number_index >= BOARD_SIZE && board_has_won(board))
            {
                ++finished_boards;

                if (finished_boards == 1)
                {
                    uint32_t score = compute_board_score(board, n);
                    printf("Score of first winning board; Part 1: %d\n", score);
                }
                else if (finished_boards == boards_count)
                {
                    uint32_t score = compute_board_score(board, n);
                    printf("Score of last winning board; Part 2: %d\n", score);
                }

                free(boards[board_index]);

                // We set the pointer to finished boards to zero, so we can skip them in later checks
                boards[board_index] = NULL;
            }
        }
    }

fail_2:
    for (size_t i = 0; i < boards_count; ++i)
        if (boards[boards_count] != NULL)
            free(boards[boards_count]);

fail_1:
    free(drawn_numbers);

fail_0:
    return exit_code;
}
