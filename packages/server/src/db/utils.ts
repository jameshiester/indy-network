import { allParsingInstructions, MongoQueryParser } from '@ucast/mongo';
import { interpret } from '@ucast/sql/typeorm';
import { IBaseSearchOptions } from 'model';
import { Repository } from 'typeorm';

const parser = new MongoQueryParser(allParsingInstructions);

const findAndCount = async <TEntity>(
  repository: Repository<TEntity>,
  { filter, offset, limit }: IBaseSearchOptions<TEntity>,
) => {
  const query = repository.createQueryBuilder('a');
  if (filter) {
    const ast = parser.parse(filter);
    const condition = interpret(ast, query);
    query.where(condition);
  }
  if (offset) {
    query.skip(offset);
  }
  if (limit) {
    query.take(limit);
  }
  const [results, totalRecords] = await query.getManyAndCount();
  return { results, totalRecords };
};

export { findAndCount };
