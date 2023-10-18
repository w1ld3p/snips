import os

# Function to count occurrences and save the last position
def count_and_save_last_position(file_path, last_position_file):
    count = 0

    # Read the last saved position
    last_position = 0
    try:
        with open(last_position_file, 'r') as last_pos_file:
            last_position = int(last_pos_file.read())
    except FileNotFoundError:
        pass

    # Check the size of the log file
    log_file_size = os.path.getsize(file_path)

    if last_position > log_file_size:
        # If last position is beyond the file size, reset to the beginning
        last_position = 0

    # Process the log file
    with open(file_path, 'r') as log_file:
        log_file.seek(last_position)
        for line in log_file:
            if "Reference=" in line:
                count += 1
            last_position = log_file.tell()

    # Save the count and last position
    with open(last_position_file, 'w') as last_pos_file:
        last_pos_file.write(str(last_position))

    return count

# Paths to the log file and last position file
log_file_path = 'FUN.log'
last_position_file = 'last_run.pos'

# Count occurrences and save last position
occurrences = count_and_save_last_position(log_file_path, last_position_file)
print(f'Number of occurrences of "Reference=": {occurrences}')

