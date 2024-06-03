#!/usr/bin/env python

import pysam, argparse
import numpy as np

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--bam', help="bam")
    parser.add_argument('--bai', help="bai")
    parser.add_argument("-o", "--output", action='store', dest='output')
    args = parser.parse_args()

    bam_file = args.bam
    bam_index = args.bai

    # Open the BAM file using pysam
    bam = pysam.AlignmentFile(bam_file, "rb", index_filename=bam_index)

    # Initialize a list to store the absolute insert sizes
    insert_sizes = []

    # Iterate over each read in the BAM file
    for read in bam:
        # Check if the read is mapped
        if not read.is_unmapped:
            # Calculate the absolute insert size and append to the list
            insert_size = abs(read.template_length)
            insert_sizes.append(insert_size)

    # Close the BAM file
    bam.close()

    # Sort the insert sizes
    sorted_insert_sizes = sorted(insert_sizes)

    # Count the occurrences of each insert size
    insert_size_counts = np.unique(sorted_insert_sizes, return_counts=True)

    # Calculate the average number of reads per insert size and write to file
    with open(args.output, "w") as f:
        for insert_size, count in zip(*insert_size_counts):
            avg_count = count / 2  # Dividing by 2 to account for paired-end reads
            f.write(f"{insert_size}\t{int(avg_count)}\n")

if __name__ == "__main__":
    main()