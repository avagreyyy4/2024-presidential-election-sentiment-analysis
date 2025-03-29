{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 6,
   "id": "8ab3a90a-330b-44af-92c1-a2fa5b2d5736",
   "metadata": {},
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "C:\\Users\\agrey25\\AppData\\Local\\Temp\\ipykernel_18376\\4103613812.py:14: DtypeWarning: Columns (8,9,10,11,18,24) have mixed types. Specify dtype option on import or set low_memory=False.\n",
      "  for chunk in pd.read_csv(input_file, chunksize=chunksize, parse_dates=[\"date\"]):\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "[DONE] Filtered data saved to: C:/Users/agrey25/Desktop/novfiltered_data.csv\n"
     ]
    }
   ],
   "source": [
    "import pandas as pd\n",
    "\n",
    "input_file = \"C:/Users/agrey25/Desktop/november_data_combined.csv\"\n",
    "output_file = \"C:/Users/agrey25/Desktop/novfiltered_data.csv\"\n",
    "\n",
    "# Filter range\n",
    "start_date = pd.to_datetime(\"2024-11-01\")\n",
    "end_date = pd.to_datetime(\"2024-11-04\")\n",
    "\n",
    "# Open output file for writing (once)\n",
    "first_chunk = True\n",
    "chunksize = 500_000  # Adjust to fit your RAM\n",
    "\n",
    "for chunk in pd.read_csv(input_file, chunksize=chunksize, parse_dates=[\"date\"]):\n",
    "    filtered = chunk[(chunk[\"date\"] >= start_date) & (chunk[\"date\"] <= end_date)]\n",
    "    \n",
    "    if not filtered.empty:\n",
    "        filtered.to_csv(output_file, mode='a', header=first_chunk, index=False)\n",
    "        first_chunk = False\n",
    "\n",
    "print(\"[DONE] Filtered data saved to:\", output_file)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "f7d2e3f3-d794-4024-bb4f-5d56f996b7ee",
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "[DONE] Saved 1370 cleaned tweets to july_chunk_clean.csv\n"
     ]
    }
   ],
   "source": [
    "import pandas as pd\n",
    "import re\n",
    "\n",
    "# Load the filtered file\n",
    "df = pd.read_csv(\"C:/Users/agrey25/Desktop/novfiltered_data.csv\", parse_dates=[\"date\"])\n",
    "\n",
    "# Select and rename columns\n",
    "df = df[[\"text\", \"lang\", \"replyCount\", \"likeCount\", \"retweetCount\", \"viewCount\", \"date\"]]\n",
    "df = df.rename(columns={\"text\": \"fullText\"})\n",
    "\n",
    "# Remove structured references to full names (like \"– Kamala Harris\" and \"Kamala Harris’s:\")\n",
    "filters = [\n",
    "    r\"-\\s*Kamala Harris\",\n",
    "    r\"-\\s*Donald Trump\",\n",
    "    r\"Kamala Harris'?s?:\",\n",
    "    r\"Donald Trump'?s?:\"\n",
    "]\n",
    "for pattern in filters:\n",
    "    df = df[~df[\"fullText\"].str.contains(pattern, case=False, regex=True)]\n",
    "\n",
    "# Text cleaning\n",
    "df[\"fullText\"] = df[\"fullText\"].str.lower()\n",
    "df[\"fullText\"] = df[\"fullText\"].str.replace(r\"@\\w+\", \" \", regex=True)        # remove mentions\n",
    "df[\"fullText\"] = df[\"fullText\"].str.replace(r\"#\\w+\", \"\", regex=True)         # remove hashtags\n",
    "df[\"fullText\"] = df[\"fullText\"].str.replace(r\"\\.\", \" \", regex=True)          # replace periods with space\n",
    "df[\"fullText\"] = df[\"fullText\"].str.replace(\"'\", \"\", regex=False)            # remove apostrophes\n",
    "df[\"fullText\"] = df[\"fullText\"].str.replace(r\"\\s+\", \" \", regex=True)         # normalize whitespace\n",
    "\n",
    "# Drop duplicates based on fullText\n",
    "df = df.drop_duplicates(subset=[\"fullText\"])\n",
    "\n",
    "# Keep only tweets that mention either candidate\n",
    "df = df[df[\"fullText\"].str.contains(r\"Trump|Donald|Harris|Kamala\", case=False, regex=True)]\n",
    "\n",
    "# Filter by language and date range\n",
    "df_ready = df[(df[\"lang\"] == \"en\") & (df[\"date\"] >= \"2024-11-01\") & (df[\"date\"] <= \"2024-11-04\")]\n",
    "\n",
    "# Save to CSV\n",
    "df_ready.to_csv(\"C:/Users/agrey25/Desktop/nov_chunk_clean.csv\", index=False)\n",
    "print(f\"[DONE] Saved {len(df_ready)} cleaned tweets to july_chunk_clean.csv\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "335b9342-9149-44d8-aa75-2b27d58c4c96",
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "<DatetimeArray>\n",
       "['2024-11-04 00:00:00', '2024-11-03 00:00:00', '2024-11-02 00:00:00',\n",
       " '2024-11-01 00:00:00']\n",
       "Length: 4, dtype: datetime64[ns]"
      ]
     },
     "execution_count": 9,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "df_ready[\"date\"].unique()\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "3d5fa6e6-0e28-4281-ba52-2a2daff7e3de",
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "from pathlib import Path\n",
    "\n",
    "# Folder where your filtered CSV files live\n",
    "data_dir = Path(\"C:/Users/agrey25/Desktop/filtered_chunks\")\n",
    "\n",
    "# Output path for the combined result\n",
    "output_path = Path(\"C:/Users/agrey25/Desktop/combined_filtered_data.csv\")\n",
    "\n",
    "# Grab all CSVs in that folder\n",
    "csv_files = sorted(data_dir.glob(\"*.csv\"))\n",
    "\n",
    "# Combine them all\n",
    "df_all = pd.concat((pd.read_csv(file) for file in csv_files), ignore_index=True)\n",
    "\n",
    "# Optional: remove duplicates if needed\n",
    "df_all = df_all.drop_duplicates()\n",
    "\n",
    "# Save to one final file\n",
    "df_all.to_csv(output_path, index=False)\n",
    "\n",
    "print(f\"[DONE] Combined {len(csv_files)} CSVs into: {output_path}\")\n"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.13.2"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
