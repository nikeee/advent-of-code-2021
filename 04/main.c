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

void print_board(number *board)
{
    for (size_t x = 0; x < BOARD_SIZE; ++x)
    {
        for (size_t y = 0; y < BOARD_SIZE; ++y)
        {
            printf("%3" SCNi8, board[x * BOARD_SIZE + y]);
        }
        printf("\n");
    }
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
    number *drawn_numbers = calloc(100, sizeof(number));
    if (drawn_numbers == NULL)
        return -1;

    size_t drawn_numbers_count = 0;
    do
    {
        int read = scanf("%" SCNi8, &drawn_numbers[drawn_numbers_count]);
        if (read != 1)
            return -1;

        ++drawn_numbers_count;
    } while (getchar() == ',');

    number *boards[100] = {NULL};
    size_t boards_count = 0;

    bool all_boards_read = false;
    while (true)
    {
        number *current_board = calloc(BOARD_NUMBER_COUNT, sizeof(number));
        if (current_board == NULL)
            return -1;

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

    for (size_t number_index = 0; number_index < drawn_numbers_count; ++number_index)
    {
        number n = drawn_numbers[number_index];

        for (size_t board_index = 0; board_index < boards_count; ++board_index)
        {
            number *board = boards[board_index];

            mark_number_as_drawn(board, n);

            // Small micro optimization: We can only have a winning board if there were at least BOARD_SIZE numbers drawn
            if (number_index >= BOARD_SIZE && board_has_won(board))
            {
                uint32_t score = compute_board_score(board, n);
                printf("Score of winning board; Part 1: %d\n", score);

                return 0;
            }
        }
    }

    // We don't free memory created with calloc(). We only have a single run and the OS frees up the memory after process termination anyways.
    // for (size_t i = 0; i < boards_count; ++i)
    //     free(boards[boards_count]);
    // free(drawn_numbers);
    return 0;
}
