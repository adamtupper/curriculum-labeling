"""
python cc_package_results.py
    --slurm-log-dir <path to slurm log directory>
    --output-dir <path to save packaged results files>
    --jobs <id1, id2, ...>
"""
import argparse
import glob
import os
import shutil
import string
import tarfile


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser()

    parser.add_argument("--slurm-log-dir", type=str, required=True)
    parser.add_argument("--jobs", type=int, nargs="+", required=True)
    parser.add_argument("--output-dir", type=str, required=True)

    return parser.parse_args()


def extract(line, prefix):
    """Extract metadata value given by `prefix` from the line if present."""
    if prefix in line:
        raw_string = line.split(prefix)[1].strip()
        return "".join(filter(lambda x: x in string.printable, raw_string))
    else:
        return None


def process_lines(lines):
    """Process lines from Slurm log file to extract metadata."""
    for line in lines:
        results_dir = extract(line, "Results will be saved to this folder:")
        if results_dir is not None:
            return results_dir


def main():
    """Main function."""
    args = parse_args()

    for i, id in enumerate(args.jobs, start=1):
        print(f"Processing Job {id} ({i}/{len(args.jobs)})...")

        # Get list of Slurm log files
        slurm_logs = glob.glob(os.path.join(args.slurm_log_dir, f"slurm-{id}_*.out"))

        # Extract results path from first the log file
        log_file = open(slurm_logs[0], "r")
        lines = log_file.readlines()
        results_dir = process_lines(lines)

        # Move Slurm log files into experiment directory
        for log_file in slurm_logs:
            shutil.copy2(log_file, results_dir)

        # Compile output files into compressed tarball
        tar_file = f"{os.path.basename(results_dir)}_job{id}.tar.gz"
        with tarfile.open(os.path.join(args.output_dir, tar_file), "w:gz") as tar:
            tar.add(results_dir, arcname=os.path.basename(results_dir))

        # Clean-up
        # shutil.rmtree(results_dir)
        # for log_file in slurm_logs:
        #     os.remove(log_file)


if __name__ == "__main__":
    main()
