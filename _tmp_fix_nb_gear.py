import json
import pathlib

path = pathlib.Path(r'c:\Users\hamod4691\Code\arctic-benthic-biodiversity\Manuscript\data_paper_manuscript.ipynb')
nb = json.loads(path.read_text(encoding='utf-8'))
changed = False
replacement_path = "merged_all_path = Path(FILEPATH).resolve().parent.parent / 'Final' / 'merged_all_final.parquet'\n"

for cell in nb.get('cells', []):
    src = cell.get('source')
    if not isinstance(src, list):
        continue

    for idx, line in enumerate(src):
        if line == "all_merged = pd.read_parquet(\"Final/merged_all_final.parquet\")\n" or line == "all_merged = pd.read_parquet('Final/merged_all_final.parquet')\n":
            src[idx:idx + 1] = [replacement_path, "all_merged = pd.read_parquet(merged_all_path)\n"]
            changed = True
            break
        if line == "gear_source = pd.read_parquet('Final/merged_all_final.parquet')\n":
            src[idx:idx + 1] = [replacement_path, "gear_source = pd.read_parquet(merged_all_path)\n"]
            changed = True
            break

    if changed:
        continue

    for idx, line in enumerate(src):
        if "has_gear_info = all_merged['gear'].notna()" in line:
            end = idx
            while end < len(src) and 'pct_without_gear = 100.0 - pct_with_gear' not in src[end]:
                end += 1
            if end >= len(src):
                raise SystemExit('could not find end of gear block')

            end += 1
            src[idx:end] = [
                "gear_source = pd.read_parquet('Final/merged_all_final.parquet')\n",
                "has_gear_info = gear_source['gear'].notna()\n",
                "n_records = len(gear_source)\n",
                "pct_with_gear = (float(has_gear_info.sum()) / float(n_records) * 100.0) if n_records > 0 else 0.0\n",
                "pct_without_gear = 100.0 - pct_with_gear\n",
            ]
            changed = True
            break

    if changed:
        break

if not changed:
    raise SystemExit('target gear block not found')

path.write_text(json.dumps(nb, ensure_ascii=False, indent=1), encoding='utf-8')
print('updated')
