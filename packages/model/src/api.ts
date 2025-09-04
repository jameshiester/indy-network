import { MongoQuery } from '@ucast/mongo';

export interface IBaseSearchOptions<TEntity> {
  filter: MongoQuery<TEntity>;
  offset?: number;
  limit?: number;
  order?: Record<string, 'ASC' | 'DESC'>;
}
