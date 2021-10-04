"""insert occtax sample data

Revision ID: cce08a64eb4f
Revises:
Create Date: 2021-10-04 11:31:50.957854

"""
import importlib

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'cce08a64eb4f'
down_revision = None
branch_labels = ('occtax-samples',)
depends_on = (
    '72f227e37bdf',  # utilisateurs samples data
    '3d0bf4ee67d1',  # geonature samples data
    'addb71d8efad',  # occtax
)


def upgrade():
    operations = importlib.resources.read_text('occtax.migrations.data', 'sample_data.sql')
    op.execute(operations)


def downgrade():
    # gn_meta.cor_dataset_protocol
    # gn_meta.cor_dataset_territory
    # gn_meta.cor_dataset_actor
    # gn_meta.cor_acquisition_framework_actor
    # gn_meta.cor_acquisition_framework_objectif
    # gn_meta.cor_acquisition_framework_voletsinp
    op.execute("""
    DELETE FROM gn_meta.t_datasets d
    USING gn_meta.t_acquisition_frameworks af
    WHERE d.id_acquisition_framework = af.id_acquisition_framework
    AND af.unique_acquisition_framework_id = '57b7d0f2-4183-4b7b-8f08-6e105d476dc5'
    """)
    op.execute("""
    DELETE FROM gn_meta.t_acquisition_frameworks af
    WHERE af.unique_acquisition_framework_id = '57b7d0f2-4183-4b7b-8f08-6e105d476dc5'
    """)
