import pandas as pd
import joblib

# === Load saved models and scalers from current directory ===
vectorizer = joblib.load('vectorizer.pkl')
standardizer = joblib.load('standard_scaler.pkl')
scaler = joblib.load('maxabs_scaler.pkl')
model_candidate = joblib.load('model_candidate.pkl')
model_sentiment = joblib.load('model_sentiment.pkl')

# === Load new data (must have 'fullText' column) ===
df_new = pd.read_csv('new_data.csv')  # Make sure this file exists and is clean!

# === TF-IDF transformation ===
X_tfidf = vectorizer.transform(df_new['fullText'])
X_tfidf_df = pd.DataFrame(X_tfidf.toarray(), columns=vectorizer.get_feature_names_out())

# === Scale features ===
X_standardized = standardizer.transform(X_tfidf_df)
X_scaled = scaler.transform(X_standardized)

# === Predict ===
df_new['candidate_pred'] = model_candidate.predict(X_scaled)
df_new['sentiment_pred'] = model_sentiment.predict(X_scaled)

# === Add confidence scores (optional but useful) ===
df_new['confidence_sentiment'] = [
    row[model_sentiment.classes_.tolist().index(pred)]
    for row, pred in zip(model_sentiment.predict_proba(X_scaled), df_new['sentiment_pred'])
]

# === Save or preview results ===
df_new.to_csv('predicted_results.csv', index=False)
print(df_new[['fullText', 'candidate_pred', 'sentiment_pred', 'confidence_sentiment']].head())
